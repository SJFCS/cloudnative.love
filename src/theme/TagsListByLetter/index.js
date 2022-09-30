import React from 'react';
// import { listTagsByLetters } from '@docusaurus/theme-common';
import { TagCloud } from 'react-tagcloud'
import { useColorMode } from '@docusaurus/theme-common';


export default function TagsListByLetter({ tags }) {

  const data = tags.map(v => {
    return {
      value: v.label,
      count: v.count,
      to: v.permalink,
    }
  })

  const luminosity = useColorMode().colorMode === 'dark' ? 'light' : 'dark';
  // custom random color options
  // see randomColor package: https://github.com/davidmerfield/randomColor
  const options = {
    luminosity,
    hue: 'blue',
  }

  const customRenderer = (tag, size, color) => (
    <span
      key={tag.value}
      style={{
        animation: 'blinker 3s linear infinite',
        animationDelay: `${Math.random() * 2}s`,
        fontSize: `${size / 2}em`,
        // border: `2px solid ${color}`,
        margin: '3px',
        padding: '3px',
        display: 'inline-block',
        // color: 'white',
        cursor: 'pointer',
        color: color,
      }}
    >
      {tag.value}
      <sup> {tag.count}</sup>
    </span>
  )

  return (
    <TagCloud className="margin-vert--lg"
      minSize={1}
      maxSize={5}
      colorOptions={options}
      tags={data}
      onClick={(tag) => {
        // console.log('clicking on tag:', tag.to)
        window.location.href = tag.to
      }}
      renderer={customRenderer}
    />
  );
}
